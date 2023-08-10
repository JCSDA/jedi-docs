# Installing Cylc on macOS

*I did this on macOS 10.15.7 (Catalina).*

After following the instructions to install cycle 7.9.1, I would suggest to follow the easiest path:

```bash
mkdir /opt
cd /opt
tar zxvf cylc-flow-7.9.1.tar.gz
ln -s ./cylc-flow-7.9.1 cycle
cp cylc/usr/bin/cylc /usr/local/bin # or wherever is in your PATH
cd /opt/cylc
make # create docs
```

Use *_sudo_* whenever needed. There is no need to define environment variables, it works fine that way.

In terms of configuration, the default config works fine on my laptop. If you want to save the config and potentially modify it:

```bash
cd /opt/cylc/etc
cylc get-site-config > global.rc
```

You can then modify the config, see:
https://cylc.github.io/cylc-doc/current/html/appendices/site-user-config-ref.html#sitercreference

I worked from basic examples:

```bash
cd /opt/cycl/etc/examples
mkdir ~/cylc-run # this is what is in the configuration by default for cylc to run
mkdir ~/cylc-run/tutorial
cp -r tutorial/ ~/cylc-run/tutorial/
cd ~/cylc-run
cylc start tutorial/oneoff/basic
```

Cylc 7.9.1 uses python2, ideally python 2.7. This is where I started to have problems as my preinstalled macOS python 2.7 was not correct for this. The symptom was an exception complaining about POLLIN not being defined in the select module (not sure anymore if it was obvious or I had to dig). If you try: 

```python
python2
import select 
select.POLLIN
File "<stdin>", line 1, in <module>
AttributeError: 'module' object has no attribute 'toto'

```

then you have the same problem.

I removed the pre-installed version of python2 from the Mac the best I could. It's all normally installed under:
```bash
/System/Library/Frameworks/Python.framework/Resources
```

I then needed to install an official version of Python 2. Brew does not install python2 anymore because it’s obsolete, so I built it from source, I fetched *python 2.7.18* from http://python.org. 
Building it is straightforward:

```bash
./configure —prefix /usr/local
make
sudo make install
```

Prefix could be anywhere convenient. In hindsight, I think I should have installed it in */opt*.

At that point there still was an issue:

```bash
~/cylc-run$ cylc start tutorial/oneoff/basic
ERROR: No hosts currently compatible with this global configuration:
  suite servers -> run hosts:
    []
  suite servers -> run host select -> rank:
    random
  suite servers -> run host select -> thresholds:
```

After trying a few times and looking at the configuration, if started very randomly once, and I got the message:

```bash
 ~/cylc-run:claude$ cylc start tutorial/oneoff/basic
            ._.                                                       
            | |                 The Cylc Suite Engine [7.9.1]         
._____._. ._| |_____.           Copyright (C) 2008-2019 NIWA          
| .___| | | | | .___|   & British Crown (Met Office) & Contributors.  
| !___| !_! | | !___.  _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
!_____!___. |_!_____!  This program comes with ABSOLUTELY NO WARRANTY;
      .___! |          see `cylc warranty`.  It is free software, you 
      !_____!           are welcome to redistribute it under certain  
2020-11-02T21:58:52Z ERROR - no HTTPS/OpenSSL support. Aborting...
2020-11-02T21:58:52Z ERROR - "No HTTPS support. Configure user's global.rc to use HTTP."
     Traceback (most recent call last):
       File "/opt/cylc-flow-7.9.1/lib/cylc/scheduler.py", line 243, in start
         self.httpserver = HTTPServer(self.suite)
       File "/opt/cylc-flow-7.9.1/lib/cylc/network/httpserver.py", line 97, in __init__
         raise CylcError("No HTTPS support. "
     CylcError: "No HTTPS support. Configure user's global.rc to use HTTP."
2020-11-02T21:58:52Z CRITICAL - Suite shutting down - "No HTTPS support. Configure user's global.rc to use HTTP."
2020-11-02T21:58:52Z INFO - DONE
Traceback (most recent call last):
  File "/opt/cylc-flow-7.9.1/bin/cylc-run", line 25, in <module>
    main(is_restart=False)
  File "/opt/cylc-flow-7.9.1/lib/cylc/scheduler_cli.py", line 134, in main
    scheduler.start()
  File "/opt/cylc-flow-7.9.1/lib/cylc/scheduler.py", line 276, in start
    raise exc
cylc.exceptions.CylcError: "No HTTPS support. Configure user's global.rc to use HTTP."
```

I looked like I had an ssl issue If I tried:

```python
python2
import ssl
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ImportError: Module _ssl is not installed
```

I had the error that the _ssl module was not installed. I eventually found that to build python from source you need:

```bash
CPPFLAGS="-I$(brew --prefix openssl)/include" LDFLAGS="-L$(brew —prefix openssl)/lib” ./configure —prefix /usr/local
make
sudo make install
```

I had openSSL installed with brew on the Mac. After this _ssl was built:

```python
python2
>>> import ssl
>>> ssl.OPENSSL_VERSION
'OpenSSL 1.1.1g  21 Apr 2020'
>>>
```

I thought I had solved the problem, but I still had the same error when issuing:

```bash
~/cylc-run:claude$ cylc start tutorial/oneoff/basic

ERROR: No hosts currently compatible with this global configuration:
  suite servers -> run hosts:
    []
  suite servers -> run host select -> rank:
    random
  suite servers -> run host select -> thresholds:
```

I debugged the code backwards from where the error was displayed in the code, I saw that it had to do with the network module, macOS and IPV6. I spare you the details, after a lot of experimenting I eventually found (back where it all started):
https://github.com/cylc/cylc-flow/issues/2689 where Oliver Sanders gives the solution.

On MacOS, whether ipv6 is enable or not, socket.getfqdn() does not return the hostname. To fix it I modified the function _get_host_info.

In /opt/cylc/lib/cylc/hostuserutil.py, line 116, replace the whole function with:

```python
def _get_host_info(self, target=None):
    """Return the extended info of the current host."""
    if target not in self._host_exs:
        if target is None:
            from sys import platform
            if platform == 'darwin':
                target = socket.gethostname()
            else:
                target = socket.getfqdn()
        try:
            self._host_exs[target] = socket.gethostbyname_ex(target)
        except IOError as exc:
            if exc.filename is None:
                exc.filename = target
            raise
    return self._host_exs[target]
```

After this, I was unfortunately back to the same error as above: 
```bash
"No HTTPS support. Configure user's global.rc to use HTTP.” 
```
I followed the advice in the text of the exception and I modified the config file:

```bash
vi /opt/cylc/etc/global.rc
[communication]
    options =  
    method = https # <— changed to http
    proxies on =
```

It finally worked using *http* instead of *https*. Since this is for development and testing only, I think this is good enough, so I left it at that since the next version of cylc will be completely different.



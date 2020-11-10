# Installing Cylc on Mac OS for the less patient

*MacOS 10.15.7 (Catalina).*

Download cylc 7.9.1
https://github.com/cylc/cylc-flow/archive/7.9.1.tar.gz

Install it:
```bash
mkdir /opt
cd /opt
tar zxvf cylc-flow-7.9.1.tar.gz
ln -s ./cylc-flow-7.9.1 cycle
cp cylc/usr/bin/cylc /usr/local/bin # or wherever is in your PATH
cd /opt/cylc
make # create docs
```

Use *_sudo_* whenever needed. There is no need to define environment variables, it works fine that way, unless you want to install it in a different location.

In terms of configuration, the default config works fine on my laptop to run a suite and tasks locally. If you want to save the configuration file and potentially modify it:

```bash
cd /opt/cylc/etc
cylc get-site-config > global.rc
```

You can then modify the config, see:
https://cylc.github.io/cylc-doc/current/html/appendices/site-user-config-ref.html#sitercreference

Copy basic examples:

```bash
cd /opt/cycl/etc/examples
mkdir ~/cylc-run # this is what is in the configuration by default for cylc to run
mkdir ~/cylc-run/tutorial
cp -r tutorial/ ~/cylc-run/tutorial/
cd ~/cylc-run
cylc start tutorial/oneoff/basic
```

Cylc 7.9.1 uses python2, ideally python 2.7. Check that your python2 is ok:

```python
python2
import select 
select.POLLIN
File "<stdin>", line 1, in <module>
AttributeError: 'module' object has no attribute 'toto'

```

If you get this exception then your pre-installed python is not suitable.

Optionally, remove the pre-installed version of python2 (probably cleaner). It's all normally installed under:
```bash
/System/Library/Frameworks/Python.framework/Resources
```

Then install an official version of Python 2. Brew does not install python2 anymore because it’s obsolete, so build it from source, fetch *python 2.7.18* from http://python.org. 
Building it is straightforward:

```bash
./configure —prefix /usr/local
make
sudo make install
```

Prefix could be anywhere convenient */opt* is a good candidate too.

```bash
~/cylc-run:claude$ cylc start tutorial/oneoff/basic

ERROR: No hosts currently compatible with this global configuration:
  suite servers -> run hosts:
    []
  suite servers -> run host select -> rank:
    random
  suite servers -> run host select -> thresholds:
```

On MacOS, whether ipv6 is enable or not, socket.getfqdn() does not return the hostname. To fix it modify the function _get_host_info.

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

Then modify the global configuration to use *http* instead of *https*:
```bash
vi /opt/cylc/etc/global.rc
[communication]
    options =  
    method = https # <— changed to http
    proxies on =
```

Building Python2 with default values does not build the ssl module, it you needed it, please see the file explain.md.



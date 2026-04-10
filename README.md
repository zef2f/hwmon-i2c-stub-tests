# hwmon i2c-stub tests ([ru](README.ru.md))

Tests for Linux hwmon drivers using the `i2c-stub` kernel module as a
software I2C bus, without requiring real hardware. Based on
[groeck/module-tests](https://github.com/groeck/module-tests), adapted
for Linux 6.12 kernel coverage testing.

## Requirements

Kernel modules:

```
CONFIG_HWMON=y
CONFIG_I2C=y
CONFIG_I2C_STUB=m
CONFIG_I2C_CHARDEV=m
```

Plus the hwmon driver module under test (e.g. `CONFIG_SENSORS_LM90=m`).

Userspace: `i2c-tools` (`i2cset`, `i2cget`).

## Usage

```
$ sudo ./run-tests.sh [driver ...]
```

Runs all drivers listed in `list.txt`, or only those specified on the
command line. Must be run as root.

Exit status codes:

- `[Ok]` — passed
- `[Failed]` — test script exited non-zero
- `[Skip]` — driver module not available

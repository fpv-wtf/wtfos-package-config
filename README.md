# wtfos-package-config

This repository implements the CLI tool `package-config` to interact with individual wtfos package's configuration options manually.

## Usage
```
Usage: package-config <subcommand> [options]

Subcommands:
    get <package>                  show all keys for package
    get <package> <key>            get value for key in package
    getsaved <package> <key>       get on disk (non-pending) value
    set <package> <key> <value>    set value for key in package
    reset <package>                forget unapplied changes
    apply <package>                apply changes and restart package units
```

### Show a current setting value
```
package-config get msp-osd debug
```

### Update settings values
```
package-config set msp-osd somebool true
package-config set msp-osd someint 4
package-config set msp-osd somestring "hello i am string"

package-config apply msp-osd
```
In order to avoid restarting services with partially incomplete configuration sets and too often, you must use `package-config apply $PACKAGE_NAME` command to finalize any settings and actually write to the packages configuration file. This works much like Betaflight's save command, except on a per-package basis and pending values only get reset on a power cycle or when you run `package-config reset $PACKAGE_NAME`.

### Show all settings for package
```
package-config get msp-osd
```

## For package authors
Your package should depend on `wtfos-package-config`.

Install your [schema.json](./testschema.json) and default [config.json](./testconfig.json) into `/opt/etc/package-config/$PACKAGE_NAME/`.

Don't forget to add a [conffiles](./conffiles) to your packages control directory to make sure opkg updates do not overwrite the users existing settings. This also means your package must be able to deal with missing keys that were added in updates, usually by defaulting to a sane value in code.

Check out the linked files above for examples, supported types and constraints. In order for a field to be settable it *must* be defined with a certain type in your schema.json. All constaints are optional and will be ignored if not persent.

Please make sure to test your schema.json to work as expected. If you get any parse errors during the set subcommand, fix them. Only standard JSON is supported, no traling commas for arrays for example.

For more details see [this wtfos-configurator issue](https://github.com/fpv-wtf/wtfos-configurator/issues/7).

### Bash script authors
To load an individual settings from your config file you can use:
```
SOME_SETTING=$(package-config getsaved $PACKAGE_NAME $SETTING_NAME)
``` 
Note: this returns "null" if the key is missing.

To load all settings in your config file into local variables you can use:
```
eval $(package-config getsaved $PACKAGE_NAME | sed -e :1 -e 's/^\([^=]*\)\-/\1_/;t1')
```
Note: missing keys are not populated

The sed is necessary in case you want to use the '-' character in your key names. The '-' will be replaced with a '_' for bash variable names.


## Development and testing

Relies on `jq` to parse and manipulate .json files.

Any new features added need to get a an appropraite test added to `test.sh`. The test set should always be ran sucsessfully before publishing any version.

To generate packages run:
```
make ipk
```
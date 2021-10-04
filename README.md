
# Envo
*Secure environment variables for Synapse*

**Importing with [Neon](https://github.com/Belkworks/NEON)**:
```lua
Envo = NEON:github('belkworks', 'envo')
```

## API

### Creation

To create an **Envo** instance, call `Envo`.  
`Envo(namespace, key) -> Envo`  
`namespace` is the header for all written values.
`key` is the value encryption key.

```lua
env = Envo('belkworks', 'this is my super secret secret!')
```

### Writing values

Assigning a value to an environment will save it to the **envo** folder in the workspace.  
It will be encrypted with the **Envo**'s encryption key.  
Assigning a value to `nil` will delete it on disk.
```lua
env.something = 'hello world'
```
**NOTE**: All values are coerced to a string!  
In the future, value typing will be supported.

### Reading values
```lua
print(env.something) -- 'hello world'
```
If a key cannot be decrypted, it will be deleted on disk.

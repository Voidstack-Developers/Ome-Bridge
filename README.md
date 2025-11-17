# Ome Framework Bridge (DEPRECATED)

> **⚠️ WARNING: This bridge is no longer maintained.**
>
> OX_inventory support has been removed from Ome Framework.
> This folder is kept for historical reference only.

---

## Historical Documentation

This folder previously contained bridge files that connected ox_inventory with the Ome Framework.

## Installation Instructions

These files need to be placed **inside** the ox_inventory resource, not run as a separate resource.

### Steps:

1. Navigate to your `ox_inventory` resource folder
2. Go to `ox_inventory/modules/bridge/`
3. Create a new folder named `ome`
4. Copy the following files into `ox_inventory/modules/bridge/ome/`:
   - `client.lua`
   - `server.lua`

### File Structure After Installation:

```
ox_inventory/
├── modules/
│   └── bridge/
│       ├── ome/
│       │   ├── client.lua  ← Copy here
│       │   └── server.lua  ← Copy here
│       ├── esx/
│       ├── qb/
│       └── ...
```

### Configuration:

After copying the files, you need to configure ox_inventory to use the Ome bridge:

1. Open your `ox_inventory` resource
2. Find the bridge configuration (usually in a config file or the main init file)
3. Set the framework to `'ome'`

Example (this may vary depending on ox_inventory version):

```lua
-- In ox_inventory config or init file
Config.Framework = 'ome'
```

or via ConVar:

```cfg
setr inventory:framework "ome"
```

### What These Bridge Files Do:

- **server.lua**: Integrates ox_inventory with Ome Framework's player management, accounts, jobs, and permissions
- **client.lua**: Handles client-side events and status updates between ox_inventory and Ome Framework

### Important Notes:

- These files must be placed inside ox_inventory, not run as a separate resource
- The circular dependency error occurs if you try to require ox_inventory modules from outside
- Make sure Ome-Framework starts before ox_inventory (check your server.cfg load order)

### Troubleshooting:

If you still get circular dependency errors:

1. Verify the files are in the correct location: `ox_inventory/modules/bridge/ome/`
2. Check that ox_inventory is configured to use the 'ome' framework
3. Ensure Ome-Framework is loaded before ox_inventory in server.cfg
4. Restart both resources completely

## Support

For issues or questions, refer to the Ome Framework documentation or ox_inventory documentation.

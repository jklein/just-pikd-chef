jp_app Cookbook
===============
Sets up the just-pikd application

Requirements
------------
#### packages
- `postgresql`

Usage
-----
#### jp_app::default
Just include `jp_app` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[jp_app]"
  ]
}
```

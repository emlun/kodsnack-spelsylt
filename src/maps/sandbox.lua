return {
  version = "1.2",
  luaversion = "5.1",
  tiledversion = "1.2.1",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 100,
  height = 100,
  tilewidth = 16,
  tileheight = 16,
  nextlayerid = 9,
  nextobjectid = 6,
  properties = {},
  tilesets = {
    {
      name = "Super Metroid",
      firstgid = 1,
      filename = "../resources/tiles/Super Metroid.tsx",
      tilewidth = 16,
      tileheight = 16,
      spacing = 1,
      margin = 1,
      columns = 55,
      image = "../resources/tiles/super-metroid.png",
      imagewidth = 950,
      imageheight = 950,
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 16,
        height = 16
      },
      properties = {},
      terrains = {},
      tilecount = 3025,
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      id = 8,
      name = "Back",
      x = 0,
      y = 0,
      width = 100,
      height = 100,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {
        ["collidable"] = false
      },
      encoding = "base64",
      compression = "zlib",
      data = "eJztwTEBAAAAwqD1T+1lC6AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAbnEAAAQ=="
    },
    {
      type = "tilelayer",
      id = 6,
      name = "Main",
      x = 0,
      y = 0,
      width = 100,
      height = 100,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {
        ["collidable"] = true
      },
      encoding = "base64",
      compression = "zlib",
      data = "eJzt2lFqwkAUhtG8mrcWl1BdV3dSu4ZuuIpckCCDpKW5/T0H5v1+TCBkJtMEAAAAAAAAAAAAAMBfetlN0+m8Xv/pOs7XhhQfAS0JDeX8jL1vPcNPJTSUhJaEhpLQktBQEloSGkpCS0JDSWhJaCgJLQkNJaEloaEktCQ0lISWhIaS0JLQUBJaEhrKoy2XM9TDPD5n3W90rveM+9FZQkNJaEloKF1bbu/JPnfjO6euDWt0bVneMY3unLo2rNG1ZTnXaM6uDWt0bXnW/Xibt57gvuVcozm7NqxR782vuc+6vL/3N3PVPyT35tzyuwcAAAAAAAAAAAAAAAAAAAAAAAB+yzfo+zrj"
    },
    {
      type = "tilelayer",
      id = 7,
      name = "Front",
      x = 0,
      y = 0,
      width = 100,
      height = 100,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {
        ["collidable"] = false
      },
      encoding = "base64",
      compression = "zlib",
      data = "eJztzjENAAAIwDCUgX9XYIGD8LTJ/kUAAAAAAAAAAAAAAAAAAAAAAAAAwI2c6nsCAAAAAAAAAAAAAAAAAAAAAAAAYKkBW5oAfg=="
    },
    {
      type = "objectgroup",
      id = 5,
      name = "Spawns",
      visible = false,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 4,
          name = "Player",
          type = "spawn-player",
          shape = "rectangle",
          x = 704,
          y = 672,
          width = 16,
          height = 16,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}

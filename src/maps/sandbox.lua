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
  nextobjectid = 34,
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
      data = "eJzt0cEJgDAURMG9GWwjNqU2ZazYbxUKmYG9L7wEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAmMmyJr0lW/v6Ca+9Ohy1U49fuKrDqN16AAAAwNQeqlEDWg=="
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
      data = "eJzt201Og0AAhmG2dFfjEdRzeZPqGbywEtINoaQdB/g6PE/CohsUXv46TLsOAAAAAAAAAAAAAOCYzn3Xff0tL5Zdl4/T2OLS731EcHUZ23zu/X8wGlrokUOPLHpk0SOLHln0yKJHFj2y6JFFjyx6ZHmGHsOY5/tpeVz0tZEx0WfocSR6ZNHjPud++XMtetxn+s5urXd4NXpc77ct3VenpvtorWPY+XEfPbK8nZY/1/w7W/d4tvksc9fhGtvw3c8/J2zdo4X5LLW2Ye45YeseLVwfa23D3H1Jj8fpkWXPHrW/X+hxez3OjzJ6ZNEjix5Z9MiiR5Yte6w9ft5Cj1rjidP1OD/K1DpOp+vRI4seWfTIokcWPbLokeW/PUq+q6w1F6AFe5wf17kAPwtzpI+wzB3De/TgNj2y6JFFjyx6ZBlaeP7MMfR49Plzbt4pdZReq1qYg5uotId7zjr0yKJHFj2y1OhxhN9zbsX5kUWPLHpkKd2vxljWUbpfvePb5n0hAAAAx/ELVxh8oA=="
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
          name = "Spawn 1",
          type = "spawn-player",
          shape = "rectangle",
          x = 704,
          y = 672,
          width = 16,
          height = 16,
          rotation = 0,
          visible = true,
          properties = {
            ["index"] = 1
          }
        },
        {
          id = 6,
          name = "Spawn 2",
          type = "spawn-player",
          shape = "rectangle",
          x = 608,
          y = 896,
          width = 16,
          height = 16,
          rotation = 0,
          visible = true,
          properties = {
            ["index"] = 2
          }
        },
        {
          id = 19,
          name = "Spawn 3",
          type = "spawn-player",
          shape = "rectangle",
          x = 144,
          y = 848,
          width = 16,
          height = 16,
          rotation = 0,
          visible = true,
          properties = {
            ["index"] = 3
          }
        },
        {
          id = 21,
          name = "Spawn 4",
          type = "spawn-player",
          shape = "rectangle",
          x = 1344,
          y = 1392,
          width = 16,
          height = 16,
          rotation = 0,
          visible = true,
          properties = {
            ["index"] = 4
          }
        },
        {
          id = 25,
          name = "Turret 1",
          type = "spawn-turret",
          shape = "rectangle",
          x = 1200,
          y = 480,
          width = 16,
          height = 16,
          rotation = 0,
          visible = true,
          properties = {
            ["facing_x"] = 0,
            ["facing_y"] = 1
          }
        },
        {
          id = 26,
          name = "Turret 2",
          type = "spaw-n-turret",
          shape = "rectangle",
          x = 80,
          y = 1024,
          width = 16,
          height = 16,
          rotation = 0,
          visible = true,
          properties = {
            ["facing_x"] = 0,
            ["facing_y"] = 1
          }
        },
        {
          id = 33,
          name = "Turret 3",
          type = "spawn-turret",
          shape = "rectangle",
          x = 1504,
          y = 864,
          width = 16,
          height = 16,
          rotation = 0,
          visible = true,
          properties = {
            ["facing_x"] = -1,
            ["facing_y"] = 0
          }
        }
      }
    }
  }
}

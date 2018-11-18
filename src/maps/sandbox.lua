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
  nextobjectid = 25,
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
      data = "eJzt20FOg0AAhlG2dFfjEdRzeZPqGbywkqYhIUgQZ5i/5b2ERVdt+Rigw7TrAAAAAAAAAAAAAACO6dx33cfP9mRrur2dri0ufesjgpvLtc1768/B1dBCjxx6ZNEjix5Z9MiiRxY9suiRRY8semTRI8s99BjmPF9Py/Oizw8yJ3oPPY5Ejyx6rHPul1+Xosc602d2tZ7hlehxu94+0nV1arqPah3Dxsc6emR5OS2/Lvk+e/e4t/Usc+fh5wLf4bOfv0/Yu4f1LKO5+4S9ezg/juauS3q0o0eWLT1K/77QY2R8ZNEjix5Z9MiiRxY9sqzpUXv+XI/RdF7S+GhrerzrkUWPLHpk0SOLHln0yPLfHlt+q9RaC/AIWoyP23qGr4U10kfY5o7hFj34nR5Z9MiiRxY9sgwt3H/mGHr89f5zbt0pZWw9V1mDW8fWHq45deiRRY8semQp0eMI/+fci/GRRY8semTZul/NsdSxdb96xrfP80IAAACO4xtKtncC"
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
        }
      }
    }
  }
}

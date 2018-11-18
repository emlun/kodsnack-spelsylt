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
      data = "eJzt201Og0AAhmG2ZVfjEdRzeZPqGbywEtJQCRpEhvkoz5OwYKMNL3+dmTYNAAAAAAAAAAAAAMAxnU9N8/a1Pdiqbi9t3+Jyqn1GcHXp27zW/hz0uhZ65NAjix5Z9MiiRxY9suiRRY8semTRI4seWfbQoxvzfG5/Hxd9vJMx0T30OBI9sugxz+2c3fup3y9Bj3nGc3al5vDW6HF93t7Tc3VsfIxKncOuj3n0yPLU/r6/5v/Zusfe1rNc78PdZ/5ov+//5+9OvRecK6xnsJ5lMPWesHUP98fB1HNJj3r0yLKkx9rfL/QYuD6y6JFFjyx6ZNEjix5Z5vQoPX6ux8D1kUWPLHpk0SOLHln0yKJHlrV7LPmuUmotwB6Nj0WN6+N8szag9lqFmtvUOVyjBz/TI4seWfTIokeWroX3zxxdj7++f5b8PcrRLb1XWYNbxtIenjll6JFFjyx6ZFmjxxF+z7kV10cWPbLokWXpcTXGUsbS42qOb5v5QgAAAI7jE0KZfUE="
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

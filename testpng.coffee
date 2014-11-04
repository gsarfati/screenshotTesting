fs      = require 'fs'
PNG     = require('pngjs').PNG

count = 0   # Count of pixel not match
percent = 0 # Equality images percentage 

rgb = 0xFFFF0000

color =
  a: (rgb >>> 24) & 0xFF
  r: (rgb >>> 16) & 0xFF
  g: (rgb >>>  8) & 0xFF
  b: (rgb >>>  0) & 0xFF

console.log process.argv
expectedImg = './image1.png' 
currentImg = './image2.png'
outputImg = './diff.png'
tolerance = 10 / 100 * 255

t = new Date().getTime()


fs.createReadStream(expectedImg)

.pipe new PNG { filterType: 4 }

.on 'parsed', ->
  expectedImg = this

  fs.createReadStream currentImg

  .pipe new PNG { filterType: 4 }

  .on 'parsed', ->
    currentImg = this
    o = new Date().getTime() - t
    console.log -1 if (expectedImg.height isnt currentImg.height) or (expectedImg.width isnt currentImg.width)

    for y in [0..expectedImg.height]
      for x in [0..expectedImg.width]
        pixelId = (expectedImg.width * y + x) << 2

        # if pixel color isnt tolerate pixel color become color
        if  ~~(expectedImg.data[pixelId] - tolerance) < currentImg.data[pixelId] > ~~(expectedImg.data[pixelId] + tolerance) or
            ~~(expectedImg.data[pixelId+1] - tolerance) < currentImg.data[pixelId+1] > ~~(expectedImg.data[pixelId+1] + tolerance) or
            ~~(expectedImg.data[pixelId+2] - tolerance) < currentImg.data[pixelId+2] > ~~(expectedImg.data[pixelId+2] + tolerance)

          # fill color
          expectedImg.data[pixelId] = color.r
          expectedImg.data[pixelId+1] = color.g
          expectedImg.data[pixelId+2] = color.b
          expectedImg.data[pixelId+3] = color.a
          count++

        else # Reduce opacity
          expectedImg.data[pixelId+3] = expectedImg.data[pixelId+3] >> 1

    # equality percent result
    percent = 100 / (expectedImg.height * expectedImg.width) * count

    expectedImg
    .pack()
    .pipe fs.createWriteStream outputImg

    # Undist time execution control
    u = new Date().getTime() - t
    console.log "equality : #{~~(100 - percent)}%"
    console.log "ouverture des fichiers : #{o}ms"
    console.log "temps d' éxécution : #{u - o}ms"
    console.log "total : #{u}ms"

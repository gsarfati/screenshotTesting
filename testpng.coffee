fs      = require 'fs'
PNG     = require('pngjs').PNG

# Color bit decomposition
extractRGBA = (color) ->
  color = parseInt color
  rgba =
    r: (color >>> 16) & 0xFF
    g: (color >>>  8) & 0xFF
    b: (color >>>  0) & 0xFF
    a: (color >>> 24) & 0xFF

fillPixel = (img, pixel, color) ->
  img[pixel]   = color.r
  img[pixel+1] = color.g
  img[pixel+2] = color.b
  img[pixel+3] = color.a

# COMMAND LINE
# <path/expectedImg> <path/currentImg>

# ARGUMENTS
# --fgcolor <int:color>
# --output <path/output.png>
# --tolerance
# --writeNbPixelDiff
# --writeTimeExecution
# --writeEqualityPercent
# --bgcolor <int:color>

# Img file
expectedImg = process.argv[2]
currentImg = process.argv[3]
outputImg = process.argv[4]

# Tolerance pixel color
tolerance = 0

fgColor = extractRGBA 0xFFFF0000
bgColor = undefined

# Output write options
writeNbPixelDiff = false
writeTimeExecution = false
writeEqualityPercent = false

for option, id in process.argv
  switch option
    when '--fgcolor'              then fgColor = extractRGBA process.argv[id + 1]
    when '--bgcolor'              then bgColor = extractRGBA process.argv[id + 1]
    when '--tolerance'            then tolerance = ~~(process.argv[id + 1] / 100 * 255)
    when '--writeNbPixelDiff'     then writeNbPixelDiff = true
    when '--writeTimeExecution'   then writeTimeExecution = true
    when '--writeEqualityPercent' then writeEqualityPercent = true

    else continue

count = 0   # Count of pixel not match
percent = 0 # Equality images percentage

startTime = new Date().getTime()

# Read Img
expectedImg = new PNG().parse(fs.readFileSync(expectedImg))

fs.createReadStream(currentImg).pipe(new PNG { filterType: 4 })

  .on 'parsed', ->
    currentImg = this
    readFileTime = new Date().getTime() - startTime
    console.log -1 if (expectedImg.height isnt currentImg.height) or (expectedImg.width isnt currentImg.width)

    # Compare pixel by pixel
    for y in [0..expectedImg.height]
      for x in [0..expectedImg.width]
        pixel = (expectedImg.width * y + x) << 2

        # If pixel color is equal or similar (tolerance)
        if  Math.abs(currentImg.data[pixel] - expectedImg.data[pixel]) <= tolerance and
            Math.abs(currentImg.data[pixel + 1] - expectedImg.data[pixel + 1]) <= tolerance and
            Math.abs(currentImg.data[pixel + 2] - expectedImg.data[pixel + 2]) <= tolerance and
            Math.abs(currentImg.data[pixel + 3] - expectedImg.data[pixel + 3]) <= tolerance

          if bgColor isnt undefined then fillPixel expectedImg.data, pixel, bgColor
          else expectedImg.data[pixel+3] = expectedImg.data[pixel+3] >> 1

        else
          fillPixel expectedImg.data, pixel, fgColor
          count++

    # Write new Image Diff at outputImg
    folder = outputImg.replace /// [\w]*.png$ ///, ''
    unless fs.existsSync folder
      fs.mkdirSync folder

    expectedImg
    .pack()
    .pipe fs.createWriteStream outputImg

    # Number of pixel are different
  if writeNbPixelDiff
    console.log count

  # Equality percent between img
  if writeEqualityPercent
    percent = ~~(100 - (100 / (expectedImg.height * expectedImg.width) * count))
    console.log "equality : #{percent}%"

  # Time execution control
  if writeTimeExecution
    endTime = new Date().getTime() - startTime
    console.log "Read file time : #{readFileTime}ms"
    console.log "Diff image time : #{endTime - readFileTime}ms"
    console.log "Total : #{endTime}ms"

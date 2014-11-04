var system  = require('system');
var fs = require('fs');
var PNG = require('pngjs').PNG;
var process = require('process');

var image1 = undefined
var image2 = undefined

var count = 0;

image1 = './image1.png';
image2 = './image2.png';

fs.createReadStream(image1)
    .pipe(new PNG({
        filterType: 4
    }))
    .on('parsed', function() {
        image1 = this;

        fs.createReadStream(image2)
        .pipe(new PNG({
            filterType: 4
        }))
        .on('parsed', function() {
            image2 = this;
            image1.size= image1.height * image1.width;
            image2.size= image2.height * image2.width;
            if(image1.height != image2.height
            || image1.width  != image2.width)
                return console.log(-1);

            for (var y = 0; y < image1.height; y++) {
                for (var x = 0; x < image1.width; x++) {
                    var idx = (image1.width * y + x) << 2;
                    //console.log(idx);
                    // invert color
                    if(image1.data[idx]   != image2.data[idx]
                    || image1.data[idx+1] != image2.data[idx+1]
                    || image1.data[idx+2] != image2.data[idx+2])
                    {
                        count++
                        image1.data[idx] = 255;
                        image1.data[idx+1] = 0;
                        image1.data[idx+2] = 0;
                    }
                    else
                    {// and reduce opacity
                        image1.data[idx+3] = image1.data[idx+3] >> 1;
                    }
                }
            }percent = parseFloat(100 / (image1.height * image1.width) * count)
            console.log('identique : ' + Math.round(100 - percent) + '%')
            console.log(count);
            image1.pack().pipe(fs.createWriteStream('diff.png'));
        });
        // for (var y = 0; y < this.height; y++) {
        //     for (var x = 0; x < this.width; x++) {
        //         var idx = (this.width * y + x) << 2;
        //         //console.log(idx);
        //         // invert color
        //         this.data[idx] = 255 - this.data[idx];
        //         this.data[idx+1] = 255 - this.data[idx+1];
        //         this.data[idx+2] = 255 - this.data[idx+2];

        //         // and reduce opacity
        //         this.data[idx+3] = this.data[idx+3] >> 4;
        //     }
        // }

    });

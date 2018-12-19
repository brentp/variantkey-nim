# variantkey

nim wrapper for [variantkey](https://github.com/Genomicsplc/variantkey).

This wrapper can encode+decode about 5 million variants per second.
The entirety of the API exposed by this library is demonstrated below:

```
import variantkey

var
  chrom = "19"
  pos = 3323934'u32
  # encode
  e = encode(chrom, pos, "A", "T")


echo e # 10959892387821256704
echo e.decode # (chrom: "19", position: 3323934, reference: "A", alternate: "T")
```

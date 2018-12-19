// VariantKey
//
// variantkey.h
//
// @category   Libraries
// @author     Nicola Asuni <nicola.asuni@genomicsplc.com>
// @copyright  2017-2018 GENOMICS plc
// @license    MIT (see LICENSE)
// @link       https://github.com/genomicsplc/variantkey
//
// LICENSE
//
// Copyright (c) 2017-2018 GENOMICS plc
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

/**
 * @file variantkey.h
 * @brief VariantKey main functions.
 *
 * The functions provided here allows to generate and process a 64 bit Unsigned Integer Keys for Human Genetic Variants.
 * The VariantKey is sortable for chromosome and position,
 * and it is also fully reversible for variants with up to 11 bases between Reference and Alternate alleles.
 * It can be used to sort, search and match variant-based data easily and very quickly.
 */

#ifndef VARIANTKEY_VARIANTKEY_H
#define VARIANTKEY_VARIANTKEY_H

#include <inttypes.h>
#include <stddef.h>
#include <stdio.h>
#include "hex.h"

typedef struct variantkey_t
{
    uint8_t chrom;   //!< Chromosome encoded number (only the LSB 5 bit are used)
    uint32_t pos;    //!< Reference position, with the first base having position 0 (only the LSB 28 bit are used)
    uint32_t refalt; //!< Code for Reference and Alternate allele (only the LSB 31 bits are used)
} variantkey_t;

/** @brief Decode a VariantKey code and returns the components as variantkey_t structure.
 *
 * @param code VariantKey code.
 * @param vk   Decoded variantkey structure.
 */
void decode_variantkey(uint64_t code, variantkey_t *vk);

/**
 * Returns a 64 bit variant key based on CHROM, POS (0-based), REF, ALT.
 * The variant should be already normalized (see normalize_variant or use normalized_variantkey).
 *
 * @param chrom      Chromosome. An identifier from the reference genome, no white-space or leading zeros permitted.
 * @param sizechrom  Length of the chrom string, excluding the terminating null byte.
 * @param pos        Position. The reference position, with the first base having position 0.
 * @param ref        Reference allele. String containing a sequence of nucleotide letters.
 *                   The value in the pos field refers to the position of the first nucleotide in the String.
 *                   Characters must be A-Z, a-z or *
 * @param sizeref    Length of the ref string, excluding the terminating null byte.
 * @param alt        Alternate non-reference allele string.
 *                   Characters must be A-Z, a-z or *
 * @param sizealt    Length of the alt string, excluding the terminating null byte.
 *
 * @return      VariantKey 64 bit code.
 */
uint64_t variantkey(const char *chrom, size_t sizechrom, uint32_t pos, const char *ref, size_t sizeref, const char *alt, size_t sizealt);

/** @brief Decode the 32 bit REF+ALT code if reversible (if it has 11 or less bases in total and only contains ACGT letters).
 *
 * @param code     REF+ALT code
 * @param ref      REF string buffer to be returned.
 * @param sizeref  Pointer to the size of the ref buffer, excluding the terminating null byte.
 *                 This will contain the final ref size.
 * @param alt      ALT string buffer to be returned.
 * @param sizealt  Pointer to the size of the alt buffer, excluding the terminating null byte.
 *                 This will contain the final alt size.
 *
 * @return      If the code is reversible, then the total number of characters of REF+ALT is returned.
 *              Otherwise 0 is returned.
 */
size_t decode_refalt_rev(uint32_t code, char *ref, size_t *sizeref, char *alt, size_t *sizealt);
size_t decode_refalt(uint32_t code, char *ref, size_t *sizeref, char *alt, size_t *sizealt);

#endif  // VARIANTKEY_VARIANTKEY_H

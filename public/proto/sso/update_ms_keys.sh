#!/bin/bash

OUTDIR="/var/www/html/proto/sso"
OUTFILE="ms_keys_$(date +%Y_%m).txt"
SYMLINK="$OUTDIR/ms_jwks.json"
BACKUP="$OUTDIR/zz_trash_ms_jwks_$(date +%Y_%m_%d).json"

cp "$SYMLINK" "$BACKUP" \
  && wget -q "https://login.microsoftonline.com/common/discovery/v2.0/keys" -O "$OUTDIR/$OUTFILE" \
  && ln -sf "$OUTDIR/$OUTFILE" "$SYMLINK"

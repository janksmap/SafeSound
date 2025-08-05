#!/bin/sh

# Create .env from .env.template if .env doesn't already exist exist
if [ ! -f .env ]; then
    cp .env.template .env
    echo ".env created from .env.template"
fi

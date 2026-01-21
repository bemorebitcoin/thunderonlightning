#!/bin/bash
R -e "pr('/plumber/plumber.R')$run(host='0.0.0.0', port=8000)"

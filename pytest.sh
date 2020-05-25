#!/usr/bin/env bash

pytest tests/ --black --cov-report=xml --cov=srv/

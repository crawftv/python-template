#!/usr/bin/env python3
"""Stores the statements that created the table for reference and for test.db creation"""
# scraped_pages = """CREATE TABLE scraped_pages
#                   (url text PRIMARY KEY,
#                   page_text text,
#                   page_code text )"""

CREATE_STORIES = """
CREATE TABLE stories
(author text,
title text,
subtitle text,
domain text,
url text)"""

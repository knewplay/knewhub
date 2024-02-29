# KnewHub

[![Test Coverage](https://api.codeclimate.com/v1/badges/da7cb86882e3074c32d8/test_coverage)](https://codeclimate.com/github/knewplay/knewhub/test_coverage)

An open learning platform for STEM.

## Author Guide

Authors use Markdown to write articles on KnewHub. In addition to regular Markdown syntax, the following custom syntax is supported:
- Code blocks from separate code files in the repository where the Markdown file lives
    + Syntax: `[codefile <relative_path>]`
    + Example: `[codefile ./code-files/code-example.c]`
- Code blocks from GitHub gists
    + Syntax: `[codegist <gist_url>]`
    + Example: `[codegist https://gist.github.com/jp524/2d00cbf0a9976db406e4369b31e25460]`
- Collapsing elements (HTML details and summary tags)
    + Syntax: `[details Hint]content[/details]`
    + Example: `[details Click Here to Display Content]Content[/details]`

## Development

[Deployment Guide](./deployment-guide.md)
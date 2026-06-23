# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-06-23

### Added

- Label each state-diagram edge with the event that triggers the transition
  (`from --> to : event_name`), so transitions leaving the same state are no
  longer ambiguous.
- Limit generation to specific classes via rake task arguments, e.g.
  `rake 'aasm_vis:generate[Job,Order]'`. With no arguments every machine is
  still generated.

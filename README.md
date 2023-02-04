# MultiTrackExport

## What does it do
It exports all selected audio tracks to the directory of the current project (the location where the .aup3 file is stored). If the project hasn't been saved yet, it will export the files to Audacity's temp directory.

## Installing the plugin
Open Audacity -> click `Tools` -> click `Nyquist Plugin Installer` -> Select the `multi-track-export.ny` file

## Exporting all audio track
You can create a macro in Audacity and tell it to run `SelectAll` followed by `MultiTrackExport` (After installing the plugin you need to restart Audacity for this option to become available)

## TODO
- Improve the algorithm that detects the project location. It's very slow at the moment.

## Other information
This Audacity Plugin is written in Nyquist using the SAL syntax.  
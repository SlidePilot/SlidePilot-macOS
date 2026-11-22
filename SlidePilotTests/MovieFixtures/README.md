Run the movie resource checks from the repository root without the app dependencies:

```sh
swiftc -module-cache-path /tmp/slidepilot-module-cache SlidePilot/Helpers/PDFPage+Extension.swift SlidePilot/Helpers/String+Extension.swift SlidePilotTests/MovieResourceChecks.swift -o /tmp/slidepilot-movie-checks
/tmp/slidepilot-movie-checks "$PWD/SlidePilotTests/MovieFixtures"
```

The small PDF fixtures exercise linked filenames, multiple annotations, bounds, embedded stream extraction, stable shared URLs, and cleanup on document replacement. The embedded stream contains test bytes rather than a playable video. Actual audio/video playback and window interactions require manual testing in the app.

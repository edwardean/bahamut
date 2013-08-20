## Songs

*For those of us who are tired of iTunes's crap*

* Current version: **0.1**
* Requires: OS X 10.8 and up
* Download: coming soon

#### What's left for 1.0

- Hope someone makes a really pretty icon for it :)
- Window title should show selected playlist
- Steal Sparkle and the auto-build stuff from Zephyros
- Keyboard shortcuts for *everything*
- Optional Menu bar interface (TunesBar port)
- Fix all the playlist- and song-selection bugs
    - When you filter a playlist, the selection doesn't follow the songs
    - Double-clicking a songs deselects it for some reason
    - When you add/remove a song, the selection doesn't follow the songs
    - When you add/remove a playlist, the selection doesn't follow the playlist
- Make the track-bar not jump after you finish dragging it
- Find (or draw?) a "pause" icon for the playlist/song currently-playing rows
- Delete songs from All Songs (and remove from every playlist)
    - This should be undo-able!
- Make "create playlist" button prettier somehow
- Figure out how to get Track info field to display "..." without tightening at every resize
- Only display track info parts that exist! ("album" sometimes doesn't, I think)
- Hasten start-up time
- Preload songs smarter
    - Make it not take 500MB of memory just because you filtered all the songs
        - Probably just needs an @autorelease{} block
    - But make the methods still load on-demand
    - Probably do it from within SDSong, so that nobody else needs to be bothered

#### To do after 1.0

- Figure out what exactly should happen when you change anything about playlist while it's playing
- Make it scriptable maybe?

#### Screenshot

![songsapp.png](songsapp.png)

#### License

> Released under MIT license.
>
> Copyright (c) 2013 Steven Degutis
>
> Permission is hereby granted, free of charge, to any person obtaining a copy
> of this software and associated documentation files (the "Software"), to deal
> in the Software without restriction, including without limitation the rights
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
> copies of the Software, and to permit persons to whom the Software is
> furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in
> all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
> THE SOFTWARE.

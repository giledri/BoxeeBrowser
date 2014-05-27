BoxeeBrowser
============

iPad app to browse my BoxeeBox media library (requires Boxee+Hacks) 

I am writing this app for several reasons:

1. I wanted to have such app and could not find it on the AppStore
2. I wanted to practice my iOS programming skills
3. I discovered Boxee+Hacks (http://boxeed.in) which makes this app possible

This app downloads the boxee catalog (sqlite3 db) using FTP from the boxer to the iPad and then display the content of the catalog (the media library) in the UI which tries to reseble the boxee UI while keeping iOS standards.

On second run (and forward) the app will first read the local copy of the catalog and try download an updated copy in the background.

The app will try to complete missing movie information using omdb API (http://www.omdbapi.com)

What's next?

1. I'm seeking way to tell the boxes to play a given movie so I can add a 'Play on Boxee' button in the app.
2. I'd like to add a boxee remote functionality in the app
3. maybe add a 'Play on iPad' functionality, although it will probably work well only if there is very good network speed between the boxee and the iPad - I will not develop streaming capabilities on the boxee for that :-)
4. Add a 'Search' button
5. Show 'Unidentified Movies'
6. Better display of Shows 
and the list goes on…


Gil
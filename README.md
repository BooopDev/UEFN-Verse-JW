
# UEFN Project: JW
This repository showcases all the code written for the JW project, completely refactored and rewritten from the ground up to be as performant as possible for large multiplayer sessions. The project utilizes async/concurrency throughout as a means to squeeze as much performance out of the Verse VM as possible whilst keeping code as simple as possible.

Although this codebase and it's associated project is now abandoned/archived, many of the core features and methodologies that I developed for JW have been refined over time and continue to be utilized in current/future projects.

## Features
JW is primarily an "only-up" type game, where the player is tasked with climbing to the top of a large vertical parkour puzzle. The code responsible for this is relatively simple but there are a few interesting concepts to point out:

### Core_Device (Entry Device)

> The Core device is the entry point for all code execution. Typically
> UEFN maps have multiple creative devices running simultaneously, but
> managing interoperability between devices can be tedious and the
> memory consumption is simply not necessary. Instead our maps use a
> single core device and we write our code in default class types, it's
> easier, cleaner and reduces memory consumption.
### Player_Data
> 
> Scaling a game to an unknown number of players is tricky and ensuring
> that we get the most performance meant we needed to start splitting
> our code up into multiple threads that can run concurrently. Using a
> player_data class that can be bound to a player when they join the
> session and destroyed when they leave, we can create an destroy new
> threads depending on the number of players, keeping performance
> stable.
### UI_Manager
> Verse UI continues to be a pain point for most projects, it's
> complicated, hard to write, hard to read and hard to debug. To help
> simplify this process, I created all the UI components in UMG and used
> the layout and structure of those widgets to inform the layout of the
> Verse UI, this made it much easier to understand visually. I also
> wanted to avoid duplicating functionality across multiple UI
> components, so I created a ui_base class that can be overridden,
> holding the all the references and methods necessary. A nice synergy
> also arises when pairing functionality like the UI_Manager with a
> player_data container that is bound to a player. All the data inside
> the UI components are stored per player, preventing the need for maps
> to track which data belongs to who.
### Utility
> Every project requires a utility file that contains all the useful
> functions that always seem to be missing from the API's we work with.
> My utility file contains functions for passing multiple parameters for
> listenable interfaces, vector math, easy debug logging, array helper
> functions and a bunch of extra stuff.

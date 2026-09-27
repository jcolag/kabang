# Kabang!

When I finished reading [**Project:  Ballad**](https://john.colagioia.net/blog/2023/08/12/project-ballad-3.html) for my [Free Culture Book Club](https://john.colagioia.net/blog/tag/bookclub), I realized that the in-story video game **Kabang!**---featured in the short story *Tesseract*---could potentially work as a real video game.  In the noted post, I even said this.

> *Tesseract* introduces Dante's Pizza and Games, Pannych and Phyr, possibly a novel sport for them to play, **Kabang!** and **“Super”-Kabang!**, Dale "The Mountain" Messner, and a bunch of minor characters.  Much like **Fall of the Kingdom**, the **Kabang!** games seem to have a fairly complete description that someone could implement.

The more thought that I gave to this, the more that **Kabang!** stood out as an almost perfect project for my blog.  The idea originates in a Free Culture work.  Bringing it to life would require programming.  It has a limited scope, with only one game mechanic.  And it would require my learning something new, which sweetened the deal for me.

As the "something new" (in 2023), I chose the [TIC-80](https://tic80.com/) "fantasy computer," and wrote the code using [Lua](https://www.lua.org/).  As a placeholder for better music, I (to my shame) asked an LLM to generate something plausible---giving me an oddball tune that sounded more mournful than what a person might hear in a 1980s video arcade---and I released it like that, publishing the full Lua code here.  For the TIC-80's "Pro" version, it can export the code including (in XML blobs) the game assets, so you have that here.

Recently, I went through to improve it, especially getting rid of any of the LLM-generated work and improving some aspects that I punted on in my first attempt.

Apart from the credit due Michael Peterson and Kevin Czapiewski for the concept in the aforementioned story made available under the terms of CC BY-SA 3.0, I should mention that the game now uses [RottenMage SpaceJacked JINGLE 01](https://freemusicarchive.org/music/sawsquarenoise/RottenMage_SpaceJacked/15_1678/) by [sawsquarenoise](https://freemusicarchive.org/music/sawsquarenoise/), made available under the terms of CC BY-SA 4.0, replacing the AI-generated track, though I left it in the code for posterity, unused alongside the attempt to map Gustav Holst's *Mars, the Bringer of War*.

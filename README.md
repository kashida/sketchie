# Sketchie

A browser application. Free hand sketches and editable texts in one document
with no page boundaries. Sketch drawings with color / transparency control and
a number of pen types. Intended for use with a stylus pen. Drag move, rotate,
and scale drawn images and texts.  Stores the document in HTML.
Three main application modes: layout (similar to Power Point where free layout
of presentation elements can be controled), drawing (similar to Photoshop with
a drawing tool selected), and text edit.


## Intended usages
- Art work sketches for e.g. traditional medium and digital paintings, as well
as for web pages and application UI.
- Art works that require free layout of images and texts, e.g. picture books,
graphical novels, or scrapbooks.
- Lightweight digital painting.
- Annotating existing images, e.g. screenshots.
- Note taking for meetings and school classes.


## Software structure
- ChromeApp. Also runs as a local server for development.
- Stores a HTML per document in Google Drive. Images are embedded as data URLs.
- Both client and dev server written in ir (https://github.com/kashida/ir2js).
Closure compiler used only for type checking.

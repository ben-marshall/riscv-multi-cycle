
SITE_DEST=./html
SITE_SRC=./
SITE_LAYOUTS=./assets/

all: graphs jekyll-build

jekyll-build:
	jekyll build -d $(SITE_DEST) -s $(SITE_SRC) --layouts $(SITE_LAYOUTS)

jekyll-serve:
	jekyll serve --watch -d $(SITE_DEST) -s $(SITE_SRC) --layouts $(SITE_LAYOUTS)

graphs:

clean:
	rm -rf ./html

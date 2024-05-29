ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)

BREW_INCLUDE_PATH = /opt/homebrew/include
BREW_LIB_PATH = /opt/homebrew/lib

all:
	gcc -undefined dynamic_lookup -dynamiclib -o priv/nif.so c_src/nif.c -I"$(ERLANG_PATH)" -I$(BREW_INCLUDE_PATH) -L$(BREW_LIB_PATH) -lvirt

clean:
	rm  -r "priv/nif.so"
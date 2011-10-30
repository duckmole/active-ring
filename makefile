.PHONY: erlang

all: erlang priv/einotify

priv/einotify: c_src/einotify.c
	gcc $< -o $@

erlang:
	@cd ebin; erl -make

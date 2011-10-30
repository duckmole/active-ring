#include <string.h>
#include <stdio.h>
#include <sys/inotify.h>
#include "einotify.h"

uint32_t decode_inotify_mask (const char* string) {
  size_t n=0;
  char *tok = NULL;
  uint32_t result = 0;
  char buf[1024];
  strcpy (buf, string);
  printf("buf: %s\n", buf);

  for (tok=strtok(buf,","); tok!=NULL; tok=strtok(NULL,",")) {
    printf("tok: %s\n", tok);

    if (strcmp (tok, "access") == 0) {
      result |= IN_ACCESS;
    }
    else if (strcmp (tok, "modify") == 0) {
      result |= IN_MODIFY;
    }
    else if (strcmp (tok, "attrib") == 0) {
      result |= IN_ATTRIB;
    }
    else if (strcmp (tok, "close_write") == 0) {
      result |= IN_CLOSE_WRITE;
    }
    else if (strcmp (tok, "close_norite") == 0) {
      result |= IN_CLOSE_NOWRITE;
    }
    else if (strcmp (tok, "close") == 0) {
      result |= IN_CLOSE;
    }
    else if (strcmp (tok, "open") == 0) {
      result |= IN_OPEN;
    }
    else if (strcmp (tok, "move") == 0) {
      result |= IN_MOVE;
    }
    else if (strcmp (tok, "moved_from") == 0) {
      result |= IN_MOVED_FROM;
    }
    else if (strcmp (tok, "moved_to") == 0) {
      result |= IN_MOVED_TO;
    }
    else if (strcmp (tok, "create") == 0) {
      result |= IN_CREATE;
    }
    else if (strcmp (tok, "delete") == 0) {
      result |= IN_DELETE;
    }
    else if (strcmp (tok, "delete_self") == 0) {
      result |= IN_DELETE_SELF;
    }
    else if (strcmp (tok, "move_self") == 0) {
      result |= IN_MOVE_SELF;
    }
  }
  return result;
}

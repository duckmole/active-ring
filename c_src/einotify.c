#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <sys/inotify.h>
#include <sys/epoll.h>
#include <unistd.h>
#include <linux/limits.h>

#define exit_if(b,s) if(b) err(1,"%s(%d): %s",__FILE__,__LINE__,s)
#define skip_space getchar

char *line = NULL;
size_t line_n = PATH_MAX;

void add_watch (char *line, int inotify) {
  
  for (i=0, c=getchar(); c!=' ' && i<PATH_MAX; c=getchar(), i++) {
    flags[i] = c;
  }
  
  ssize_t size, bufsize;
  uint32_t mask, watch;
  char length;
  char *buf;

  size = read (STDIN_FILENO, &mask, 4);
  exit_if (size != 4, "Unable to read watch mask from stdin");
  size = read (STDIN_FILENO, &length, 1);
  exit_if (size != 1, "Unable to read path length from stdin");
  bufsize = length + 7;
  buf = (char *)malloc(bufsize);
  memset (buf, '\0', bufsize);
  size = read (STDIN_FILENO, buf+6, length);
  exit_if (size != length, "Unable to read path from stdin");
  
  watch = inotify_add_watch (inotify, buf+6, mask);
  exit_if (watch == -1, "Unable to add an inotify watch");

  memset (buf, 1, 1);
  memcpy (buf+1, &watch, 4);
  memcpy (buf+5, &length, 1);
  size = write (STDOUT_FILENO, buf, bufsize-1);
  exit_if (size != bufsize-1, "Unable to write add watch response to stdout");
  free (buf);
  return;
}

void handle_command (char *line, int inotify) {
  if (*line == 'W') {
    add_watch (line+2, inotify);
  }
  return;
}

void notify (struct inotify_event* event) {
  char buf[9];
  ssize_t size;
  FILE* file;

  memset (buf, 2, 1);
  memcpy (buf+1, &(event->wd), 4);
  memcpy (buf+5, &(event->mask), 4);
  
  file = fopen ("einotify.out", "w");

  fprintf (file, "Notified: %d, %d, %s\n", event->wd, event->mask,
	   event->name);
  fclose (file);

  size = write (STDOUT_FILENO, buf, 9);
  exit_if (size != 9, "Unable to write event to stdout");
  return;
}

void read_inotify (int inotify) {
  char buf[1024];
  char *ptr;
  ssize_t size, count;
  struct inotify_event *event;

  size = read (inotify, buf, count);
  exit_if (size == -1, "Unable to read from inotify fd");
  ptr = buf;
  while (size > sizeof (struct inotify_event)) {
    event = (struct inotify_event *)ptr;
    notify (event);
    ptr += sizeof (struct inotify_event);
    size -= sizeof (struct inotify_event);
  }
}

int main (int argc, char *argv[]) {
  int epoll, inotify, result;
  struct epoll_event pevent;

  inotify = inotify_init ();
  exit_if (inotify == -1, "unable to initialise inotify");

  epoll = epoll_create (2);
  exit_if (epoll == -1, "unable to create epoll");
  pevent.events = EPOLLIN;
  pevent.data.fd = inotify;
  result = epoll_ctl (epoll, EPOLL_CTL_ADD, inotify, &pevent);
  exit_if (result == -1, "unable to add inotify to epoll");
  pevent.data.fd = STDIN_FILENO;
  result = epoll_ctl (epoll, EPOLL_CTL_ADD, STDIN_FILENO, &pevent);
  exit_if (result == -1, "unable to add stdin to epoll");
  line = (char *)malloc(line_n);

  fprintf (stderr, "einotify ready\n");

  for (;;) {
    result = epoll_wait (epoll, &pevent, 1, -1);
    exit_if (result == -1, "error while waiting for epoll");
    if (pevent.data.fd == STDIN_FILENO) {
      while (getline (&line, &line_n, stdin) != -1) {
	handle_command (line, inotify);
      }
    } else if (pevent.data.fd == inotify) {
      read_inotify (inotify);
    }
  }
}




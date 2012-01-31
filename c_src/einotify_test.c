#include <stdlib.h>
#include <stdio.h>
#include <sys/inotify.h>
#include <check.h>
#include "einotify.h"

START_TEST (decode_inotify_mask_test) {
  fail_unless (decode_inotify_mask ("access") == IN_ACCESS, NULL);
  fail_unless (decode_inotify_mask ("open") == IN_OPEN, NULL);
  fail_unless (decode_inotify_mask ("create") == IN_CREATE, NULL);
  fail_unless (decode_inotify_mask ("move") == IN_MOVE, NULL);
  fail_unless (decode_inotify_mask ("move,create") == (IN_MOVE|IN_CREATE), NULL);
  fail_unless (decode_inotify_mask ("move,open,create") == (IN_MOVE|IN_CREATE|IN_OPEN), NULL);
}
END_TEST

Suite * einotify_suite (void) {
  Suite *s = suite_create ("einotify");
  TCase *tc_core = tcase_create ("Core");
  tcase_add_test (tc_core, decode_inotify_mask_test);
  suite_add_tcase (s, tc_core);

  return s;
}

int main (void) {
  int number_failed;
  Suite *s = einotify_suite ();
  SRunner *sr = srunner_create (s);
  srunner_run_all (sr, CK_NORMAL);
  number_failed = srunner_ntests_failed (sr);
  srunner_free (sr);
  return (number_failed == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
}

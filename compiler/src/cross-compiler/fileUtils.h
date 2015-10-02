#ifndef _FILEUTILS_
#define _FILEUTILS_

#ifdef	__cplusplus
extern "C" {
#endif

#include <stdio.h>

typedef struct binaryFile BinaryFile;
struct binaryFile {
  FILE* descriptor;

  size_t (*read)(BinaryFile* file, void *ptr, size_t size, size_t nmemb);
  size_t (*write)(BinaryFile* file, const void *ptr, size_t size, size_t nmemb);
  long (*tell)(BinaryFile* file);
  int (*seek)(BinaryFile* file, long deplacement, int origine);
  void (*rewind)(BinaryFile* file);
  int (*close)(BinaryFile* file);
};

BinaryFile* newBinaryFile(const char *path, const char *mode);

#ifdef	__cplusplus
}
#endif

#endif

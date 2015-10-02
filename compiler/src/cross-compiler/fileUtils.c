#include "fileUtils.h"
#include <stdio.h>
#include <stdlib.h>

size_t func_read(BinaryFile* file, void *ptr, size_t size, size_t nmemb);
size_t func_write(BinaryFile* file, const void *ptr, size_t size, size_t nmemb);
long func_tell(BinaryFile* file);
int func_seek(BinaryFile* file, long deplacement, int origine);
void func_rewind(BinaryFile* file);
int func_close(BinaryFile* file);

BinaryFile* newBinaryFile(const char *path, const char *mode) {
  BinaryFile* stream = malloc(sizeof(BinaryFile));
  
  stream->descriptor = fopen(path, mode);

  stream->read = &func_read;
  stream->write = &func_write;
  stream->tell = &func_tell;
  stream->seek = &func_seek;
  stream->rewind = &func_rewind;
  stream->close = &func_close;
}

size_t func_read(BinaryFile* file, void *ptr, size_t size, size_t nmemb) {
  return fread(ptr, size, nmemb, file->descriptor);
}

size_t func_write(BinaryFile* file, const void *ptr, size_t size, size_t nmemb) {
  return fwrite(ptr, size, nmemb, file->descriptor);
}

long func_tell(BinaryFile* file) {
  return ftell(file->descriptor);
}

int func_seek(BinaryFile* file, long deplacement, int origine) {
  return fseek(file->descriptor, deplacement, origine);
}

void func_rewind(BinaryFile* file) {
  return rewind(file->descriptor);
}

int func_close(BinaryFile* file) {
  int err = fclose(file->descriptor);
  free(file);
  return err;
}


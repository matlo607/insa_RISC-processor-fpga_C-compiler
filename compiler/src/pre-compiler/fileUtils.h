/* fileUtils.h */
#ifndef _FILEUTILS_H
  #define _FILEUTILS_H
#endif

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* fichier contenant les étiquette à remplacer */
FILE * fd;


/* ouvre le fichier texte qui contiendra l'assembleur généré */
void initOutFile();

/* 
 * A utiliser lorsque la compilation n'a pu finir
 * => Suppression du fichier assembleur qui n'a pas été généré 
 * complètement du fait de l'erreur de compilation
 */
void deleteOutFile();

/*
 * Remplace les labels par les adresses de lignes
 * qui conviennent
 * tabLabel tableau contenant l'adresse de chaque label (indice i = label $i)
 */
void replaceLabel(int * tabLabel);

/** \file printf.c
 * Simplified printf() and sprintf() implementation - prints formatted string to
 * PUTCHAR_PROTOTYPE (or whereever). Most common % specifiers are supported. It costs you about
 * 3k FLASH memory - without floating point support it uses only 1k ROM!
 * \author Freddie Chopin, Martin Thomas, Marten Petschke and many others
 * \date 16.2.2012
 */

#include <stdarg.h>  // (...) parameter handling

/*
+=============================================================================+
| options
+=============================================================================+
*/
//#define INCLUDE_FLOAT  // this enables float in printf() and costs you about 2kByte ROM

/*
+=============================================================================+
| global declarations
+=============================================================================+
*/

int printf(const char *format, ...);
int sprintf(char *buffer, const char *format, ...);
void long_itoa (long, int, int, void (*) (char));  //heavily used by printf()

#ifdef __GNUC__
	extern int __io_putchar(int ch);
  #define PUTCHAR_PROTOTYPE __io_putchar
#else
	extern int fputc(int ch, FILE *f);
  #define PUTCHAR_PROTOTYPE fputc
#endif /* __GNUC__ */

char *SPRINTF_buffer;
static void putc_strg(char);  // the put() function for sprintf()
static int vfprintf(void (*) (char), const char *format, va_list arg);  //generic print

/*
+=============================================================================+
| global functions
+=============================================================================+
*/
int printf(const char *format, ...)
{
	va_list arg;

	va_start(arg, format);
	vfprintf((void (*) (char)) &PUTCHAR_PROTOTYPE, format, arg);
	va_end(arg);

	return 0;
}

int sprintf(char *buffer, const char *format, ...)
{
	va_list arg;

	SPRINTF_buffer = buffer;  //Pointer auf einen String in Speicherzelle abspeichern

	va_start(arg, format);
	vfprintf((&putc_strg), format, arg);
	va_end(arg);

	*SPRINTF_buffer ='\0';  // append end of string

	return 0;
}


/*
+=============================================================================+
| local functions
+=============================================================================+
*/
// putc_strg() is the putc()function for sprintf()
static void putc_strg(char character)
{
	*SPRINTF_buffer = (char)character;  // just add the character to buffer
	 SPRINTF_buffer++;

}

/*--------------------------------------------------------------------------------+
 * vfprintf()
 * Prints a string to stream. Supports %s, %c, %d, %ld %ul %02d %i %x  %lud  and %%
 *     - partly supported: long long, float (%ll %f, %F, %2.2f)
 *     - not supported: double float and exponent (%e %g %p %o \t)
 *--------------------------------------------------------------------------------+
*/
static int vfprintf(void (*putc)(char), const char* str,  va_list arp)
	{
	int d, r, w, s, l;  //d = char, r = radix, w = width, s = zeros, l = long
	char *c;  // for the while loop only

#ifdef INCLUDE_FLOAT
	float f;
	long int m, mv, p, w2;
#endif

	while ((d = *str++) != 0) {
		if (d != '%') {
			(*putc)(d);
			continue;
			}
		d = *str++;
		w = r = s = l = 0;
		if (d == '%') {
			(*putc)(d);
			d = *str++;
			}
		if (d == '0') {
			d = *str++; s = 1;  //padd with zeros
			}
		while ((d >= '0')&&(d <= '9')) {
			w += w * 10 + (d - '0');
			d = *str++;
			}
		if (s) w = -w;  //padd with zeros if negative

#ifdef INCLUDE_FLOAT
		w2 = 2;  //default decimal places = 2
		if (d == '.'){
			d = *str++; w2 = 0; }
		while ((d >= '0')&&(d <= '9')) {
			w2 += w2 * 10 + (d - '0');
			d = *str++;
			}
#endif

		if (d == 's') {
			c = va_arg(arp, char*);
			while (*c)
				(*putc)(*(c++));
			continue;
			}
		if (d == 'c') {
			(*putc)((char)va_arg(arp, int));
			continue;
			}
		if (d == 'u') {  // %ul
			r = 10;
			d = *str++;
			}
		if (d == 'l') {  // long =32bit
			l = 1;
			if (r == 0) r = -10;
			d = *str++;
			}
		if (d =='\0')
			break;  //avoid crashing if format string is buggy
		if (d == 'u')
			r = 10;  //     %lu,    %llu
		else
			if (d == 'd' || d == 'i') {
				if (r == 0)
					r = -10;
				}  //can be 16 or 32bit int
			else
				if (d == 'X' || d == 'x')
					r = 16;  // 'x' added by mthomas
				else
					if (d == 'b')
						r = 2;
#ifdef INCLUDE_FLOAT
					else
						if (d == 'f' || d == 'F') {
							f = va_arg(arp, double);
							if (f >= 0.0) {
								r = 10;
								mv = f;
								m = mv;
								}
							else
								{
								r = -10;
								mv = f;
								f = -f;
								m = f;  // f and m are always positive
								}
							long_itoa(mv, r, w, (putc));
							if (w2 != 0) {
								putc('.');
								f = f - m;
								w = -w2; p = 1;
								while (w2--)
									p = p*10;
								m = f*p;
								long_itoa(m, 10, w, (putc));
								}
							l = 3;  //do not continue with long
							}
#endif
						else
							str--;  // normal character
		
		if (r == 0)
			continue;
		if (l == 0) {
			if (r > 0) {  //unsigned
				long_itoa((unsigned long)va_arg(arp, int), r, w, (putc));  //needed for 16bit int, no harm to 32bit int
				}
			else  //signed
				long_itoa((long)va_arg(arp, int), r, w, (putc));
			}
		else
			if (l == 1) {  // long =32bit
				long_itoa((long)va_arg(arp, long), r, w, (putc));  //no matter if signed or unsigned
				}
		}

	return 0;
	}

void long_itoa (long val, int radix, int len, void (*putc) (char))
	{
	char c, sgn = 0, pad = ' ';
	char s[20];
	int  i = 0;

	if (radix < 0) {
		radix = -radix;
		if (val < 0) {
			val = -val;
			sgn = '-';
			}
		}
	if (len < 0) {
		len = -len;
		pad = '0';
		}
	if (len > 20) return;
	do {
		c = (char)((unsigned long)val % radix);  //cast!
		if (c >= 10)
			c += ('A' - 10);  //ABCDEF
		else
			c += '0';  //0123456789
		s[i++] = c;
		val = (unsigned long)val / radix;  //cast!
		} while (val);

	if ((sgn != 0) && (pad != '0'))
		s[i++] = sgn;
	while (i < len)
		s[i++] = pad;
	if ((sgn != 0) && (pad == '0'))
		s[i++] = sgn;

	do
		(*putc)(s[--i]);
	while (i);
	}

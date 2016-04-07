#include <xkbcommon/xkbcommon.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define DFLT_RULES "evdev"
#define DFLT_MODEL "pc105"
#define DFLT_LAYOUT "us"

#define STRLEN(s) (s ? strlen(s) : 0)
#define STR(s) (s ? s : "")

void parseArgs(int argc, char **argv, struct xkb_rule_names *names)
{
    int i;
    char *tmp, *rule_path;
    FILE *file;
    int len_rule_path;
    char buf[1024] = {0, };

    if (argc < 2)
    {
        rule_path = getenv("RULE_FILE_PATH");

	if (!rule_path)
        {
            printf("Failed to get RULE_FILE_PATH !\n");
            return;
        }

        printf("Cache file rule from %s file\n", rule_path);

        file = fopen(rule_path, "r");
        if (!file) return;

        while (!feof(file))
        {
            fscanf(file, "%s", buf);
            if (strstr(buf, "rules") > 0)
            {
                tmp = strtok(buf, "=");
                tmp = strtok(NULL, "=");
                if (tmp) names->rules= strdup(tmp);
            }
            else if (strstr(buf, "model") > 0)
            {
                tmp = strtok(buf, "=");
                tmp = strtok(NULL, "=");
                if (tmp) names->model= strdup(tmp);
            }
            else if (strstr(buf, "layout") > 0)
            {
                tmp = strtok(buf, "=");
                tmp = strtok(NULL, "=");
                if (tmp) names->layout= strdup(tmp);
            }
            else if (strstr(buf, "variant") > 0)
            {
                tmp = strtok(buf, "=");
                tmp = strtok(NULL, "=");
                if (tmp) names->variant= strdup(tmp);
            }
            else if (strstr(buf, "options") > 0)
            {
                tmp = strtok(buf, "=");
                tmp = strtok(NULL, "=");
                if (tmp) names->options= strdup(tmp);
            }
        }

        fclose(file);
    }
    else
    {
        for (i = 1; i < argc; i++)
        {
            printf("Cache file rule from argument\n");

            if (strstr(argv[i], "-rules") > 0)
            {
                tmp = strtok(argv[i], "=");
                tmp = strtok(NULL, "=");
                names->rules= strdup(tmp);
            }
            else if (strstr(argv[i], "-model") > 0)
            {
                tmp = strtok(argv[i], "=");
                tmp = strtok(NULL, "=");
                names->model = strdup(tmp);
            }
            else if (strstr(argv[i], "-layout") > 0)
            {
                tmp = strtok(argv[i], "=");
                tmp = strtok(NULL, "=");
                names->layout = strdup(tmp);
            }
            else if (strstr(argv[i], "-variant") > 0)
            {
                tmp = strtok(argv[i], "=");
                tmp = strtok(NULL, "=");
                names->variant = strdup(tmp);
            }
            else if (strstr(argv[i], "-options") > 0)
            {
                tmp = strtok(argv[i], "=");
                tmp = strtok(NULL, "=");
                names->options = strdup(tmp);
            }
        }
    }
}

void checkRules(struct xkb_rule_names *names)
{
   if (!names->rules)
   {
      printf("Set default rules: %s\n", DFLT_RULES);
      names->rules = strdup(DFLT_RULES);
   }
   else printf("Current rules: %s\n", names->rules);

   if (!names->model)
   {
      printf("Set default model: %s\n", DFLT_MODEL);
      names->model = strdup(DFLT_MODEL);
   }
   else printf("Current model: %s\n", names->model);

   if (!names->layout)
   {
      printf("Set default layout: %s\n", DFLT_LAYOUT);
      names->layout = strdup(DFLT_LAYOUT);
   }
   else printf("Current layout: %s\n", names->layout);

   if (!names->variant) printf("There is no variant\n");
   else printf("Current variant: %s\n", names->variant);

   if (!names->options) printf("There is no options\n");
   else printf("Current options: %s\n", names->options);
}

int main(int argc, char **argv)
{
    struct xkb_context *ctx;
    struct xkb_keymap *map;
    struct xkb_rule_names names;
    char *keymap_path = NULL;
    char *keymap_string = NULL;
    char *cache_path = NULL;
    FILE *file = NULL;
    int len_cache_path;
    
    memset(&names, 0, sizeof(names));

    parseArgs(argc, argv, &names);

    checkRules(&names);

    ctx = xkb_context_new(0);
    if (!ctx) {
       printf("Failed to generate a xkb context file\n");
       return 0;
    }

    keymap_path = getenv("LOCAL_KEYMAP_PATH");

    if (!keymap_path)
    {
        printf("Failed to get LOCAL_KEYMAP_PATH !\n");
        return 0;
    }

    xkb_context_include_path_append(ctx, keymap_path);

    map = xkb_map_new_from_names(ctx, &names, 0);

    keymap_string = xkb_map_get_as_string(map);

    if (!keymap_string) {
        printf("Failed convert keymap to string\n");
        return 0;
    }

    len_cache_path = STRLEN(names.rules) + STRLEN(names.model) + STRLEN(names.layout) + STRLEN(names.variant) + STRLEN(names.options) + sizeof("xkb") + 5;
    cache_path = (char *)calloc(1, len_cache_path);
    snprintf(cache_path, len_cache_path, "%s-%s-%s-%s-%s.xkb", STR(names.rules), STR(names.model), STR(names.layout), STR(names.variant), STR(names.options));

    file = fopen(cache_path, "w");
    if (fputs(keymap_string, file) < 0)
    {
        printf("Failed  to write keymap file: %s\n", cache_path);
        fclose(file);
        unlink(cache_path);
    }
  else
    {
        printf("Success to make keymap file: %s\n", cache_path);
        fclose(file);
    }

    if (names.rules) free(names.rules);
    if (names.model) free(names.model);
    if (names.layout) free(names.layout);
    if (names.variant) free(names.variant);
    if (names.options) free(names.options);
    if (cache_path) free(cache_path);
    xkb_keymap_unref(map);
    xkb_context_unref(ctx);

    return 0;
}

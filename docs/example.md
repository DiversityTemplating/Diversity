Annotated specification
=======================
The heart of Diversity is the component configuration file ```diversity.json```
which should follow the specification and validate against
[this schema](../validation/diversity.schema.json)

Here we are going to go through the schema piece by piece and explain the
different parts.

  1. [Name](#name)
  1. [Version](#version)
  1. [Grouping](#grouping)
  1. [Template](#template)
  1. [Style](#style)
  1. [Script](#script)
  1. [Dependencies](#dependencies)
  1. [i18n](#i18n)
  1. [l10n](#l10n)
  1. [Context](#context)
  1. [Settings](#settings)
  1. [Settings Form](#settings-form)
  1. [Angular](#angular)
  1. [Title](#title)
  1. [Description](#description)
  1. [Thumbnail](#thumbnail)


### Name

```diversity.json``` is a always an object.

**Name** is the name of the component, should be unique and can contain the letters,
underscore and hyphen (actually minus sign).

```json
{
  "name": "my-awesome-cmpnt"
}
```


### Version
**version** property is a string with the components version number.

The version should follow the [semamtic version](http://semver.org/) standard,
i.e. ```MAJOR.MINOR.PATCH```.  

Ex "0.2.0", "1.0.3", "0.107.0"

```json
{
  "name": "my-awesome-cmpnt",
  "version": "0.2.12"
}
```


### Grouping
**grouping** is a list of names of "groups" or "tags" this component conceptually belongs to. This
is used for sorting and choosing what component can go where.

```json
{
  "name": "my-awesome-cmpnt",
  "version": "0.2.12",
  "grouping": ["article", "inline"]
}
```


### Template

```json
{
  "name": "my-awesome-cmpnt",
  "version": "0.2.12",
  "template": "awesome.mustache.html"
}
```

The **template** property is either a string, or a list of strings, with the
value being either an uri or a file path pointing to a mustache template. The
file path is relative to the root of the component.

This is the base template for the component, and it's this one that will be
rendered by the backend. Even if it's a list of templates only one will be
rendered, it's the renderers responsibility to check configuration or choose
which one. This can be used to allow for different looks of the same component.

This value is optional, if not specified it basically means that the component
is just a library.

### Style

The **style** property is either a string, or a list of strings, with the value
being an uri or a file path pointing to a CSS file. The file path is relative to
the root of the component.

In contrast to **template** all styles in a list will be loaded by the renderer
in the order specified, *unless* another component already have loaded the exact
same uri/filepath. This means that if two components both want the same CSS
file it will only be loaded once.

This value is optional.

Ex.

```json
{
  "name": "my-awesome-cmpnt",
  "version": "0.2.12",
  "template": "awesome.mustace.html",
  "style": ["reset.css","awesome.css"]
}
```

### Script

The **script** property is either a string, or a list of strings, with the value
being an uri or a file path pointing to a javascript file. The file path is
relative to the root of the component.

In contrast to **template** all scripts in a list will be loaded by the renderer
in the order specified, *unless* another component already have loaded the exact
same uri/filepath. This means that if two components both want the same script
file it will only be loaded once.

This value is optional.

Ex.

```json
{
  [...]
  "script": [
    "//cdnjs.cloudflare.com/ajax/libs/marked/0.3.2/marked.min.js",
    "src/module.js",
    "src/awesome.js"
  ]
}
```

### Dependencies

At the heart of an Diversity component is it's **dependencies** mapping. This
declares what other components this component depends on and also specifies
which version (similiar to bower.json or package.json).

Which version is needed can be specifies in a number of ways, **dependencies**
works the same as the
[semver package](https://www.npmjs.org/doc/misc/semver.html) for nodejs.

This basically means that you probably want to use a ```^```` or a ```~```
before the version number to get "latest non breaking version that is at least
*this*".

The renderer will see to it that all **dependencies** will be loaded *before*
this components scripts etc are loaded. Note that depending on a component that
has a **template** defined does *not* mean that its template gets rendered, only
scripts,styles and dependencies.

The AngularJS framework is handled by the **angular** property and should
therefore be excluded from **dependencies**

This value is optional.

Ex.

```json
{
  [...]
  "dependencies": {
    "tws-bootrstrap": "*",
    "tws-api": "^0.4.2"
  }
}
```

## i18n

TODO

    "i18n": {
      "description": "An object pointing to the translation potfiles for admin and frontend.",
      "type":        "object",
      "properties": {
        "admin": {
          "description": "potfile for admin strings: translatable strings in diversity.json and option schema.",
          "$ref":        "#/definitions/filename",
          "pattern":     "\\.pot$"
        },
        "frontend": {
          "description": "potfile for frontend strings: translatable strings in the rendered component.",
          "$ref":        "#/definitions/filename",
          "pattern":     "\\.pot$"
        }
      }
    },

This value is optional.


### l10n

TODO

This value is optional.


    "l10n": {
      "description": "An object pointing to po-files for each language.",
      "type":        "object",
      "patternProperties": {
        "^[a-z]{2}(-[A-Z]{2})?$": {
          "type": "object",
          "properties": {
            "admin": {
              "description": "po-file for admin strings.",
              "$ref":        "#/definitions/filename",
              "pattern":     "\\.po$"
            },
            "frontend": {
              "description": "po-file for frontend strings.",
              "$ref":        "#/definitions/filename",
              "pattern":     "\\.po$"
            }
          }
        }
      }
    },


### Context

**context**  context is an object which values defines API queries, in JSON-RPC
2.0-format (omitting id and jsonrpc keys), to feed to the mustache template
when it's rendered. In the mustache template the result can be found as a
property on the ```context``` variable.

Ex.
```json
{
  [...]
  "context": {
    "webshop": {
      "method": "Webshop.get",
      "params": [11011]
    }
  }
}
```

```html
<h1>{{#lang}}{{ webshop.name }}{{/lang}}</h1>
```


### Settings

**settings** is a JSON Schema that defines what settings this component exposes to
the user. An object **settings** is a available when rendering the mustache
template.

**settings** can be either a string with file path to the schema or the actual
schema inlined.

This value is optional.


```json
{
  [...]
  "settings": {
    "type": "object",
    "properties": {
      "size": {
        "title": "Size of awesomeness"
        "type": "string",
        "enum": ["small","large","awesome"]
      }
    }
  }
}
```

### Settings Form
The **settings** JSON Schema is used as a basis for the administration gui. But the schema alone
does not have all the info needed to produce a good UI. For instance is this *string* an input or
a textarea? **settingsForm** includes a *form definition*, which is a list of extra options in the
format that [Angular Schema Form](https://github.com/Textalk/angular-schema-form) uses.

This value is optional.


```json
{
  [...]
  "settings": {
    "type": "object",
    "properties": {
      "comment": {
        "title": "Comment",
        "type": "string"
      }
    }
  },
  "settingsForm": [
    {
      "key": "comment",
      "type": "textarea"

    }
  ]
}
```


### Angular

AngularJS is the preferred framework for components, but a component does not
have to use it, or for that matter use any script at all.

If it does, a component *should* create its own AngularJS module, and the name
should be specified as the value of the property **angular**. This can also be
seen as a dependency declaration, in fact if the component  does not create a
module but needs angular **angular** should be set to true.

AngularJS is loaded if any component defines a module (or sets *true*) and
should therefor **not** be listed as a dependency.

It's recommended that the module name is the same as the component name but
camelized.

This value is optional.

```json
{
  [...]
  "angular": "myAwesomeCmpnt"
}
```

### Title

**title** is a string that can be used in the admin part of the component.

The value is optional.


### Description

**description** is a string that can be used in the admin part of the component.

The value is optional.


### Thumbnail

An url to a thumbnail that can be used in the admin part of the component.

This value is optional.

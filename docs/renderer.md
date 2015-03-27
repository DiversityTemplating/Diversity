Rendering diversity
===================

Terminology
-----------

  * **Component** - A specific diversity component in a specific version.

  * **ComponentSet** - A collection of components, with no more than one version of the same
    component.  It is responsible to fetch all dependencies, render lists of scripts, styles and
    angularBootstrap.

  * **Registry** - A registry holds components of different versions.  You can use it to get the
    component, or see what components and versions are available.  Notably, there is a **Local
    Registry** for files on the server, and a **Diversity-API Registry** for fetching from the
    diversity-api.

  * **Engine** - The program that can take Settings, and with the help of a Registry render HTML
    from all the Components in that.

  * **Specification** - The contents of a Components `diversity.json`.

  * **Assets** - All files that belongs to a Component.

  * **Settings** - An object structure specifying component and it's settings recursively according
    to the components' settings-schema in Specification.

  * **SettingsSchema** - The `settings` part of Specification (that can be either inlined in
    Specification or referenced by a URL)


Rendering a component
---------------------

Collect the `hash` (so named in https://mustache.github.io/mustache.5.html):


### language

2 letter isocode, defaulting to "en".


### context

The `context` should be built up based on the `context` in Specification.

There are several types of context parameters.  The first two must be implemented:

  * `prerequisite` - The provided `context` from calling application.
  * `rendered` - Something that the Engine should be able to compile from knowing the component
    with sub-components and all dependencies being rendered.  This includes:
    * `scripts` - An array of URL's to all scripts needed.
    * `styles` - An array of URL's to all stylesheets needed.
    * `angularBootstrap` - The javascript function call to bootstrap all angular modules needed, or
      `null` if no component needs angular.
    * `l10n` - An array with an object for each component that in the Specification has
      `l10n.<language>.view` (or `i18n.<language>.view` for backward compatibility), containing:
      * `component` - Name of the component the translations belong to.
      * `messages` - A JSON-string with the contents of the i18n-file.
  * `rest` - Future plans…
  * `jsonrpc` - Future plans…


It could look a bit like this in the Specification:

```json
{
  "name":    "page-component",
  "version": "1.2.3",
  "context": {
    "title": {
      "type":        "prerequisite",
      "description": "The page title."
    },
    "scripts":          {"type": "rendered"},
    "styles":           {"type": "rendered"},
    "l10n":             {"type": "rendered"},
    "angularBootstrap": {"type": "rendered"}
  }
}
```

The Engine should take care to loop through all keys in `context`.  If a `prerequisite` is needed
byt not supplied, rendering should be halted and an error raised stating the context missing and
it's description.

The `rendered` type context keys need not be rendered unless asked for. (NB: See deprecated
angularBootstrap, scripts, and styles below.)

(To handle sloppy component specs, all `context` provided by the calling application could be added
to rendering `context`.  This is done today in for example diversity-ruby.)


### settings

These are the Components Settings, matching SettingsSchema from Specification.

The settings should be available to the mustache rendering.

#### Subrendering format diversity

If an (sub-)object in `settings` matches a property with `"format": "diversity"` in the schema,
that object should be treated as a base `settings` and fed into the rendering.  The object must
have the key `component`, saying which component should be rendered.  It might have `version` - a
semver version specification, and it might have `settings` that will be fed into rendering of THAT
component.  The resulting HTML of this rendering shall be added to `componentHTML` in this same
object.

Note that this must be done for places in the schema defined by `properties`,
`additionalProperties` and `items`.

These objects should keep their `component` and `version`, but remove `settings`.  This is to get
less data (especially in the root `settingsJSON`), and because no component should use the settings
of a sub-component.

#### Validation

At least in a development scenario, the Settings should be validated against the SettingsSchema for
each component.  `settings` not matching the schema must still be available to the component in
rendering.


### settingsJSON

A JSON version of the `settings` hash.


### angularBootstrap, scripts, and styles

**Deprecated**: Remove this when the root components request this from context.

For backwards compatibility, the root component (path = '/') in a rendering could get
`angularBootstrap`, `scripts`, and `styles`.


### lang lambda

A lambda function for `lang` should be available in the mustache rendering.  It should replace the
string `lang` with the current `language` code.

NB: This must work with the delimiter changed, at least to `[[]]`.  In the PHP mustache, the
sub-render method expects the original delimiter so diversity-php has a hack to replace
`[[` with `{{`…


ComponentSet
------------

The ComponentSet must keep Components in order.  A Components dependencies must be placed before
that component in the list, to load scripts and bootstrap angular modules in the correct order.

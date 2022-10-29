---
title: Resource List
layout: project
navbar: true
---

This is a list of (hopefully) useful resources, broken down by category.  Feel
free to reach out to me with suggestions.

## Table of Contents

{% for cat in site.data.resourcelist.categories -%}
* [{{ cat }}](#{{ cat | slugify }})
{% endfor %}

{% assign resources = site.data.resourcelist.resources | sort: "title" %}

{% for cat in site.data.resourcelist.categories %}
## [{{ cat }}](#{{ cat | slugify}}){:name={{ cat | slugify }}}

{% for res in resources -%}
{%- for c in res.categories -%}
{%- if c == cat %}
* [{{ res.title | escape | replace: "|", "\|" }}]({{ res.link }})
  {%- if res.format %} ({{ res.format }}){% endif %} {% if res.amazon_link
  %}&middot; ([Amazon]({{ res.amazon_link }})){% endif -%}
{%- if res.summary %}
  
  {{ res.summary }}
{% endif -%}
{% endif -%}
{% endfor -%}
{% endfor %}
{% endfor %}

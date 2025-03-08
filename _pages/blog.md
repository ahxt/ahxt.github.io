---
layout: default
title: blog
permalink: /blog1
---


<br>
<div style="text-align:left;margin-bottom:5px">Hope these will be as helpful to you today as they will be for future me.
</div>
<div style="text-align:left;margin-bottom:5px">
    <a href="{{ site.baseurl }}/tags">view by tags</a>: <b>&nbsp;</b>
    {% for tag in site.tags %}
        <a href="{{ site.baseurl }}/tags/#{{ tag[0] }}">{{ tag[0] }} ({{ tag[1].size }})</a> <b>&nbsp;</b>
    {% endfor %}
</div>
<hr>



{% assign posts_by_year = site.posts | group_by_exp: "post", "post.date | date: '%Y'" %}

{% for year in posts_by_year %}
<h3>{{ year.name }}</h3>
<ul>
{% for post in year.items %}
<li>{{ post.date | date: '%m/%d/%Y' }} » <strong><a href="{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a></strong> <span style="float: right;" id="post-tags" >[{% for tag in post.tags %}<a href="{{ site.baseurl }}/tags/#{{ tag }}">{{ tag }}</a>{% if forloop.last == false %}, {% endif %}{% endfor %}]</span></li>
{% endfor %}
</ul>
{% endfor %}

# Decidim::Ideas

**Important:** This project is currently in development and not meant for production
use

Decidim::Ideas provides a participatory space to collect ideas from participants.
It's like initiatives, but without signatures and promoter committee. Meant for idea
collection in less formal participatory processes.

Ideas can be created by any user of the platform. Prior to be published an idea
must be approved by an administrator. An idea may contain attachments and comments
from other users as well.

## Usage

This plugin provides:

* A CRUD engine to manage ideas.

* Public views for ideas via a high level section in the main menu.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-ideas'
```

And then execute:

```bash
bundle
bundle exec rails decidim_ideas:install:migrations
bundle exec rails db:migrate
```

## Database

The database requires the extension pg_trgm enabled. Contact your DBA to enable it.

```sql
CREATE EXTENSION pg_trgm;
```

## Seeding example data

In order to populate the database with example data proceed as usual in rails:

```bash
bundle exec rails db:seed
```

## Aditional considerations

### Cookies

This engine makes use of cookies to store large form data. You should change the
default session store or you might experience problems.

Check the [Rails configuration guide](http://guides.rubyonrails.org/configuring.html#rails-general-configuration)
in order to get instructions about changing the default session store.

## License

This engine is distributed under the GNU AFFERO GENERAL PUBLIC LICENSE.

## Credits

This engine is based on code from decidim-initiatives

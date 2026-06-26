import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';

export async function GET(context) {
  const posts = await getCollection('blog');
  const sorted = posts.sort(
    (a, b) => new Date(b.data.date).getTime() - new Date(a.data.date).getTime()
  );

  return rss({
    title: 'Mirzam',
    description: 'Programming things I guess.',
    site: context.site,
    stylesheet: '/rss-style.xsl',
    items: sorted.map((post) => ({
      title: post.data.title,
      description: post.data.description ?? '',
      pubDate: post.data.date,
      link: `/blog/${post.slug}/`,
      categories: post.data.tags ?? [],
    })),
    customData: `<language>en-us</language>`,
  });
}

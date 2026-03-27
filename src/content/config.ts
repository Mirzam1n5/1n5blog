import { defineCollection, z } from 'astro:content';

const blog = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    date: z.coerce.date(),
    description: z.string().optional(),
    tags: z.array(z.string()).optional(),
  }),
});

const gallery = defineCollection({
  type: 'data',
  schema: z.object({
    title: z.string(),
    date: z.coerce.date(),
    image: z.string(),
    caption: z.string().optional(),
    source: z.string().optional(),       
    source_url: z.string().optional(),   
  }),
});

export const collections = { blog, gallery };
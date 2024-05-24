import { load as cheerioLoad, type CheerioAPI } from "cheerio";

interface ExtendedCheerioAPI {
}

const extendedApi: ExtendedCheerioAPI = {
};

/** Extension of Cheerio's load function that adds extra query plugins. */
export function load(html: string) {
	const $ = cheerioLoad(html);
    Object.assign($.fn, extendedApi);
    return $ as CheerioAPI & ExtendedCheerioAPI;
}

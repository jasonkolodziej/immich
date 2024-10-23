/// <reference types="chromecast-caf-sender" />

import { createApiKey, deleteApiKey, getApiKeys, Permission } from '@immich/sdk';

const CAST_API_KEY_NAME = 'cast';

const FRAMEWORK_LINK = 'https://www.gstatic.com/cv/js/sender/v1/cast_sender.js?loadCastFramework=1';

export const loadCastFramework = (() => {
  let promise: Promise<typeof cast> | undefined;

  return () => {
    if (promise === undefined) {
      promise = new Promise((resolve) => {
        const script = document.createElement('script');
        script.src = FRAMEWORK_LINK;
        window.__onGCastApiAvailable = (isAvailable) => {
          if (isAvailable) {
            cast.framework.CastContext.getInstance().setOptions({
              receiverApplicationId: 'BBBF7E5B',
              autoJoinPolicy: chrome.cast.AutoJoinPolicy.ORIGIN_SCOPED,
            });

            resolve(cast);
          }
        };
        document.body.appendChild(script);
      });
    }
    return promise;
  };
})();

export const isCasting = (): boolean => {
  return cast.framework.CastContext.getInstance().getCurrentSession() !== null;
};

export const createCastApiKey = async () => {
  try {
    const data = await createApiKey({
      apiKeyCreateDto: {
        name: CAST_API_KEY_NAME,
        permissions: [Permission.AssetView],
      },
    });
    return data;
  } catch (error) {
    console.error('Failed to create cast api key', error);
  }
};

export const getCastApiKey = async () => {
  const currentKeys = await getApiKeys();

  let previousKey = currentKeys.find((key) => key.name == 'cast');

  if (previousKey) {
    await deleteApiKey({ id: previousKey.id });
  }

  return await createCastApiKey();
};

export const castAsset = async (url: string) => {
  const apiKey = await getCastApiKey();

  if (!apiKey) {
    console.error('No cast api available');
    return;
  }

  let contentType: string | null = null;

  await fetch(url, { method: 'HEAD' }).then((response) => {
    contentType = response.headers.get('content-type');
    console.log(url, contentType);
  });

  if (!contentType) {
    console.error('Could not get content type for url ' + url);
    return;
  }

  const authenticatedUrl = `${url}&apiKey=${apiKey.secret}`;

  console.log(authenticatedUrl);
  console.log(contentType);

  const mediaInfo = new chrome.cast.media.MediaInfo(authenticatedUrl, contentType);

  const castSession = cast.framework.CastContext.getInstance().getCurrentSession();

  const request = new chrome.cast.media.LoadRequest(mediaInfo);
  if (!castSession) {
    return;
  }
  return castSession.loadMedia(request);
};

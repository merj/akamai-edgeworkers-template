import { logger } from 'log';

import { getHelloWorldValue, reqDetailsToString } from './utils';

// https://techdocs.akamai.com/edgeworkers/docs/event-handler-functions#onclientrequest
export function onClientRequest(request: EW.IngressClientRequest) {
	logger.debug(`onClientRequest: ${reqDetailsToString(request)}`);

	request.respondWith(
		200,
		{},
		`<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="UTF-8">
		<title>Akamai EdgeWorkers Hello World ${VERSION}</title>
	</head>
	<body>
		<p>Hello World From Akamai EdgeWorkers!</p>
		<p>${getHelloWorldValue()}</p>
	</body>
</html>`,
	);
	return;
}

// https://techdocs.akamai.com/edgeworkers/docs/event-handler-functions#onoriginrequest
// export function onOriginRequest(request: EW.IngressOriginRequest) {
// 	logger.debug(`onOriginRequest: ${reqDetailsToString(request)}`);
// }

// https://techdocs.akamai.com/edgeworkers/docs/event-handler-functions#onoriginresponse
// export function onOriginResponse(
// 	request: EW.EgressOriginRequest,
// 	response: EW.EgressOriginResponse,
// ) {
// 	logger.debug(`onOriginResponse: ${reqDetailsToString(request)}`);
// }

// https://techdocs.akamai.com/edgeworkers/docs/event-handler-functions#onclientresponse
// export function onClientResponse(
// 	request: EW.EgressClientRequest,
// 	response: EW.EgressClientResponse,
// ) {
// 	logger.debug(`onClientResponse: ${reqDetailsToString(request)}`);
// }

// https://techdocs.akamai.com/edgeworkers/docs/event-handler-functions#responseprovider
// export async function responseProvider(request: EW.ResponseProviderRequest) {
// 	logger.debug(`responseProvider: ${reqDetailsToString(request)}`);
// }

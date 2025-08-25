// intentionally in this separate file to showcase bundling
export function getHelloWorldValue() {
	// VERSION is injected by esbuild, see build.sh and src/defines.d.ts
	return `${VERSION} @ ${new Date().toISOString()}`;
}

export function reqDetailsToString(
	request:
		| EW.IngressClientRequest
		| EW.IngressOriginRequest
		| EW.EgressOriginRequest
		| EW.EgressClientRequest
		| EW.ResponseProviderRequest,
) {
	// Available built-in variables
	return `${VERSION} method=${request.method} url=${request.url} path=${request.path} query=${request.query}`;
}

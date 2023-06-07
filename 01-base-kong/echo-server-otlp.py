#!/bin/python3
from flask import Flask, request

from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.resources import SERVICE_NAME, Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.trace.propagation.tracecontext import TraceContextTextMapPropagator

# Service name is required for most backends
resource = Resource(attributes={
    SERVICE_NAME: "echo-service-backend"
})

provider = TracerProvider(resource=resource)
processor = BatchSpanProcessor(OTLPSpanExporter(endpoint="http://jaeger-collector:4318/v1/traces"))
provider.add_span_processor(processor)
trace.set_tracer_provider(provider)

tracer = trace.get_tracer(__name__)
app = Flask(__name__)

response = 'PATH: {}<br> \
METHOD: {}<br>\
<br>\
HEADERS: {}<br>'

@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def catch_all(path):
  if 'traceparent' in request.headers:
    try:
      # This creates a new span that's the child of the current one, if it exists
      carrier = {'traceparent': request.headers['traceparent']}

      ctx = TraceContextTextMapPropagator().extract(carrier=carrier)
      with tracer.start_as_current_span("echo-backend: {} /{}".format(request.method, path), ctx) as span:
        span.set_attribute('backend-path', '/' + path)
        span.set_attribute('consumer-name', request.headers['x-consumer-username'])
        span.set_attribute('consumer-id', request.headers['x-consumer-id'])
        if 'x-anonymous-consumer' in request.headers:
          span.set_attribute('unauthenticated', request.headers['x-anonymous-consumer'])
        else:
          span.set_attribute('unauthenticated', 'false')
        
        # print and return http body
        return response.format('/' + path, request.method + "<br>! Tracing from parent !", "<br>" + "<br>".join("{!s}: {!r}".format(k, v) for k, v in request.headers))
    except:
      return response.format('/' + path, request.method + "<br>! Failed to trace from parent !", "<br>" + "<br>".join("{!s}: {!r}".format(k, v) for k, v in request.headers))
  else:
    with tracer.start_as_current_span("echo-backend: {} /{}".format(request.method, path)) as span:
      return response.format('/' + path, request.method + "<br>! New trace !", "<br>" + "<br>".join("{!s}: {!r}".format(k, v) for k, v in request.headers))

if __name__ == '__main__':
  app.run(host='0.0.0.0', port=8080)

/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* $Id: PDFDocumentHandlerMaker.java 1242848 2012-02-10 16:51:08Z phancock $ */

package org.apache.fop.render.pdf;

import org.apache.fop.apps.FOUserAgent;
import org.apache.fop.apps.MimeConstants;
import org.apache.fop.render.intermediate.AbstractIFDocumentHandlerMaker;
import org.apache.fop.render.intermediate.IFContext;
import org.apache.fop.render.intermediate.IFDocumentHandler;

/**
 * Intermediate format document handler factory for PDF output.
 */
public class PDFDocumentHandlerMaker extends AbstractIFDocumentHandlerMaker {

    private static final String[] MIMES = new String[] {MimeConstants.MIME_PDF};

    /** {@inheritDoc} */
    public IFDocumentHandler makeIFDocumentHandler(FOUserAgent ua) {
        PDFDocumentHandler handler = new PDFDocumentHandler();
        handler.setContext(new IFContext(ua));
        if (ua.isAccessibilityEnabled()) {
            ua.setStructureTreeEventHandler(handler.getStructureTreeEventHandler());
        }
        return handler;
    }

    /** {@inheritDoc} */
    public boolean needsOutputStream() {
        return true;
    }

    /** {@inheritDoc} */
    public String[] getSupportedMimeTypes() {
        return MIMES;
    }

}

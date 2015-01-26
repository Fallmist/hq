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

/* $Id: InheritedPropFunction.java 1328963 2012-04-22 20:09:42Z gadams $ */

package org.apache.fop.fo.expr;

import org.apache.fop.fo.FOPropertyMapping;
import org.apache.fop.fo.properties.Property;

/**
 * Class modelling the inherited-property-value Property Value function. See
 * Sec. 5.10.4 of the XSL-FO standard.
 */
public class InheritedPropFunction extends FunctionBase {

    /** {@inheritDoc} */
    public int getRequiredArgsCount() {
        return 0;
    }

    @Override
    /** {@inheritDoc} */
    public int getOptionalArgsCount() {
        return 1;
    }

    @Override
    /** {@inheritDoc} */
    public Property getOptionalArgDefault(int index, PropertyInfo pi) throws PropertyException {
        if ( index == 0 ) {
            return getPropertyName ( pi );
        } else {
            return super.getOptionalArgDefault ( index, pi );
        }
    }

    /** {@inheritDoc} */
    public Property eval(Property[] args, PropertyInfo pInfo) throws PropertyException {
        String propName = args[0].getString();
        if (propName == null) {
            throw new PropertyException("Incorrect parameter to inherited-property-value function");
        }

        int propId = FOPropertyMapping.getPropertyId(propName);
        if (propId < 0) {
            throw new PropertyException(
                    "Unknown property name used with inherited-property-value function: "
                        + propName);
        }
        return pInfo.getPropertyList().getInherited(propId);
    }

}
